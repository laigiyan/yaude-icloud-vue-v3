<template>
  <a-modal
    :title="title"
    :width="width"
    :visible="visible"
    switchFullscreen
    @ok="handleOk"
    :okButtonProps="{ class:{'jee-hidden': disableSubmit} }"
    @cancel="handleCancel"
    cancelText="关闭">
    <a-form ref="form" :model="model" >
      <a-row>
        <a-col :span="24" >
          <a-form-model-item label="項目名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="projectName">
            <a-select v-model="model.projectName"  placeholder="请选择項目"  :disabled="true">
              <a-select-option v-for="project in projects":value="project.text"  >{{project.text}}</a-select-option>
            </a-select>
          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-model-item label="网络名称" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="networkName">
            <a-select v-model="model.networkName" @change="getSubnets"  placeholder="请选择网络名称" :disabled="true">
              <a-select-option v-for="network in networks":value="network.text" >{{network.text}}</a-select-option>
            </a-select>
          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-model-item label="子网名称" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="subnetName">
            <a-select v-model="model.subnetName" @change="getFloatip" placeholder="请选择子网名称" :disabled="true">
              <a-select-option v-for="subnet in subnets":value="subnet.text" >{{subnet.text}}</a-select-option>
            </a-select>
          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-model-item label="浮动ip" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="floatIp">
            <a-select v-model="model.floatIp" @change="getFloatip" placeholder="请选择子网名称" :disabled="true">
              <a-select-option v-for="floatip in floatips":value="floatip.value" >{{floatip.value}}</a-select-option>
            </a-select>
          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-model-item label="描述" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="represent">
            <a-input v-model="model.represent" placeholder="请输入描述" :disabled="true" ></a-input>
          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-model-item label="合约日期启" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="startTime">
            <j-date v-model="model.startTime" placeholder="请选择开始时间" date-format="YYYY-MM-DD" style="width: 60%" ></j-date>
          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-model-item label="合约日期止" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="endTime">
            <j-date v-model="model.endTime" placeholder="请选择终止时间" date-format="YYYY-MM-DD" style="width: 60%" ></j-date>
          </a-form-model-item>
        </a-col>
        <a-col :span="24">
          <a-form-model-item label="映射vm_ip" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="mapperIp">
            <a-input v-model="model.mapperIp" placeholder="请输入映射vm_ip"  ></a-input>
          </a-form-model-item>
        </a-col>
      </a-row>
    </a-form>
  </a-modal>
</template>

<script>

  import { httpAction, getAction } from '@/api/manage'
  export default {
    name: 'OsFloatipAdjustModal',
    components: {
    },

    data () {
      return {
        model:{
        },
        form: this.$form.createForm(this),
        title:'',
        width:800,
        visible: false,
        disableSubmit: false,
        labelCol: {
          xs: { span: 24 },
          sm: { span: 5 },
        },
        wrapperCol: {
          xs: { span: 24 },
          sm: { span: 16 },
        },
        confirmLoading: false,
        validatorRules: {

        },

        url: {
          adjust: "/os/osApplyFloatip/adjust",
          getNetwork: "/os/osApplyFloatip/getNetwork",
          getSubnets: "/os/osApplyFloatip/getSubnets",
          getFloatip: "/os/osApplyFloatip/getFloatip",
          getProject: "/os/osApply/getProject",
        },
        projects:[],
        networks:[],
        subnets:[],
        floatips:[]

      }
    },
    created () {

    },
    methods: {
      adjust (record) {
        this.form.resetFields();
        this.model = Object.assign({}, record);
        this.visible = true;
        this.getNetwork(this.model);
        this.getProjects(this.model);
      },
      handleOk () {
        let that = this;
        let projectId = "";
        let method = 'post';
        let httpurl=this.url.adjust;
        that.projects.forEach((r)=>{
          if(r.text==that.model.projectName){
            that.projectId = r.value;
          }
        })
        let a =that.projects;
        let b = that.model.projectName;
        let c = this.projectId;
        debugger
        let formData={
          projectName: this.model.projectName,
          projectId: this.projectId,
          networkName: this.model.networkName,
          options: "2",
          subnetName: this.model.subnetName,
          subnetId: this.model.subnetId,
          floatIp: this.model.floatIp,
          represent: this.model.represent,
          startTime: this.model.startTime,
          endTime: this.model.endTime,
          mapperIp: this.model.mapperIp
        }
        debugger
        httpAction(httpurl,formData,method).then((res)=>{
          if(res.success){
            that.$message.success(res.message);
            that.$emit('ok');
          }else{
            that.$message.warning(res.message);
          }
        }).finally(() => {
          that.confirmLoading = false;
          that.close();
        })
      },
      getProjects(record){
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getProject;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.projects.push({
                value:r.projectId,
                text:r.projectName,
              })
            })
          }
        })
      },
      getNetwork(record){
        this.networks=[];
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getNetwork;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.networks.push({
                value:r.networkId,
                text:r.networkName
              })
            })
          }
        })
      },
      getSubnets(){
        const that = this;
        this.subnets=[];
        this.networks.forEach((r)=>{
          if(r.text==that.model.networkName){
            that.model.networkId = r.value;
          }
        })
        let method = "post";
        let httpurl = this.url.getSubnets;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            result.forEach((r)=>{
              this.subnets.push({
                value:r.subnetId,
                text:r.subnetName
              })
            })
          }
        })
      },
      getFloatip(){
        this.floatips=[];
        let method = "post";
        let httpurl = this.url.getFloatip;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result;
            result.forEach((r)=>{
              this.floatips.push({
                value:r.floatIp,
                text:r.floatIp
              })
            })
          }
        })
      },



      close () {
        this.$emit('close');
        this.visible = false;
      },


      submitCallback(){
        this.$emit('ok');
        this.visible = false;
      },
      handleCancel () {
        this.close()
      }
    }
  }
</script>