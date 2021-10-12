<template>
  <a-spin :spinning="confirmLoading">
    <j-form-container :disabled="formDisabled">
      <a-form-model ref="form" :model="model" :rules="validatorRules" slot="detail">
        <a-row>
          <a-col :span="24">
            <a-form-model-item label="网络名称" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="networkName">
            <!--  <a-input v-model="model.networkName" placeholder="请输入网络名称"  ></a-input>-->
              <a-select v-model="model.networkName" @change="getSubnets"  placeholder="请选择网络名称" :disabled="editable">
                <a-select-option v-for="network in networks":value="network.text" >{{network.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="子网名称" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="subnetName">
             <!-- <a-input v-model="model.subnetName" placeholder="请输入子网名称"  ></a-input>-->
              <a-select v-model="model.subnetName" placeholder="请选择子网名称" :disabled="editable">
                <a-select-option v-for="subnet in subnets":value="subnet.text" >{{subnet.text}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>
          <!--<a-col :span="24">
            <a-form-model-item label="浮动ip" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="floatIp">
              &lt;!&ndash;<a-input v-model="this.floatip" placeholder="请输入浮动ip"  ></a-input>&ndash;&gt;
              <a-select v-model="model.floatIp" @change="getFloatip" placeholder="请选择子网名称" :disabled="editable" >
                <a-select-option v-for="floatip in floatips":value="floatip.value" >{{floatip.value}}</a-select-option>
              </a-select>
            </a-form-model-item>
          </a-col>-->
          <a-col :span="24">
            <a-form-model-item label="描述" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="represent">
              <a-input v-model="model.represent" placeholder="请输入描述"  :disabled="editable"></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="申请时间" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="startTime">
              <j-date placeholder="请选择申请时间" v-model="model.startTime"  style="width: 100%" :disabled="justable"/>
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="映射vm_ip" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="mapperIp">
              <a-input v-model="model.mapperIp" placeholder="请输入映射vm_ip"  :disabled="justable"></a-input>
            </a-form-model-item>
          </a-col>
          <a-col :span="24" v-show="showoption">
            <a-form-model-item label="审核意见" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="optionsText" >
              <a-textarea v-model="model.optionsText" placeholder="请输入审核意见" ></a-textarea>
            </a-form-model-item>
          </a-col>
        </a-row>
      </a-form-model>
    </j-form-container>
  </a-spin>
</template>

<script>

  import { httpAction, getAction } from '@/api/manage'
  import { validateDuplicateValue } from '@/utils/util'

  export default {
    name: 'OsApplyFloatipForm',
    components: {
    },
    props: {
      //表单禁用
      disabled: {
        type: Boolean,
        default: false,
        required: false
      }
    },
    data () {
      return {
        model:{
         },
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
          networkName: [
            { required: true, message: '请选择网络名称!'},
          ],
          subnetName: [
            { required: true, message: '请选择子网!'},
          ],
          floatIp: [
            { required: true, message: '请选择浮动ip!'},
          ],
        },
        url: {
          add: "/os/osApplyFloatip/add",
          edit: "/os/osApplyFloatip/edit",
          queryById: "/os/osApplyFloatip/queryById",
          getNetwork: "/os/osApplyFloatip/getNetwork",
          getSubnets: "/os/osApplyFloatip/getSubnets",
         // getFloatip: "/os/osApplyFloatip/getFloatip",
          agree: "/os/osOption/agree",
          refuse: "/os/osOption/refuse"
        },
        networks:[],
        subnets:[],
        floatips:[],
        editable: false,
        justable: false,
        showoption: false
      }
    },
    computed: {
      formDisabled(){
        return this.disabled
      },
    },
    created () {
       //备份model原始值
      this.modelDefault = JSON.parse(JSON.stringify(this.model));
      this.getNetwork(this.modelDefault);
    },
    methods: {
      add () {
        this.edit(this.modelDefault);
      },
      edit (record) {
        this.model = Object.assign({}, record);
        this.visible = true;
        this.showoption = this.model.showoption;
        if(this.model.options=="1" || (this.model.options=="2" && this.model.status!=null) ){
          this.editable=true
          this.justable=true
        }else if(this.model.options=="2" && this.model.status==null){
          this.editable=true
          this.justable=false
        }
      },
      submitForm () {
        const that = this;
        // 触发表单验证
        this.$refs.form.validate(valid => {
          if (valid) {
            that.confirmLoading = true;
            let httpurl = '';
            let method = '';
            if(!this.model.id){
              httpurl+=this.url.add;
              method = 'post';
            }else{
              httpurl+=this.url.edit;
               method = 'put';
            }
            httpAction(httpurl,this.model,method).then((res)=>{
              if(res.success){
                that.$message.success(res.message);
                that.$emit('ok');
              }else{
                that.$message.warning(res.message);
              }
            }).finally(() => {
              that.confirmLoading = false;
            })
          }

        })
      },
      //同意
      agree(){
        const that = this;
        let method = "post";
        this.model.applyType = "2";
        let httpurl = this.url.agree;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            that.$message.success(res.message);
            that.$emit('ok');
            that.loadData();
          }else{
            that.$message.warning(res.message);
          }
        }).finally(() => {
          that.confirmLoading = false;
        })
      },
      //拒绝
      refuse(){
        const that = this;
        this.model.applyType = "2";
        let method = "post";
        let httpurl = this.url.refuse;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            that.$message.success(res.message);
            that.$emit('ok');
            that.loadData();
          }else{
            that.$message.warning(res.message);
          }
        }).finally(() => {
          that.confirmLoading = false;
        })

      },

      getNetwork(record){
        this.model = Object.assign({}, record);
        let method = "post";
        let httpurl = this.url.getNetwork;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result
            debugger
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
            debugger
            result.forEach((r)=>{
              this.subnets.push({
                value:r.subnetId,
                text:r.subnetName
              })
            })
          }
        })
      },
     /* getFloatip(){
        let method = "post";
        let httpurl = this.url.getFloatip;
        httpAction(httpurl,this.model,method).then((res)=>{
          if(res.success){
            const result = res.result;
            debugger
            result.forEach((r)=>{
              this.floatips.push({
                value:r.floatIp,
                text:r.floatIp
              })
            })
          }
        })
      }*/
    }
  }
</script>