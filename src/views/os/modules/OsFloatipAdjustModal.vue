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
          <a-form-model-item label="申请时间" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="startTime">
            <j-date placeholder="请选择申请时间" v-model="model.startTime"  style="width: 100%" />
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
          getFloatip: "/os/osApplyFloatip/getFloatip"
        },
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
      },
      handleOk () {
        let that = this;
        let method = 'post';
        let httpurl=this.url.adjust;
        let formData={
          networkName: this.model.networkName,
          options: "2",
          subnetName: this.model.subnetName,
          subnetId: this.model.subnetId,
          floatIp: this.model.floatIp,
          represent: this.model.represent,
          startTime: this.model.startTime,
          mapperIp: this.model.mapperIp
        }
        httpAction(httpurl,formData,method).then((res)=>{
          if(res.success){
            that.$message.success(res.message);
            that.loadData();
            that.$emit('ok');
          }else{
            that.$message.warning(res.message);
          }
        }).finally(() => {
          that.confirmLoading = false;
          that.close();
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