<template>
  <a-spin :spinning="confirmLoading">
    <j-form-container :disabled="formDisabled">
      <a-form-model ref="form" :model="model" :rules="validatorRules" slot="detail">
        <a-row>
          <a-col :span="24">
            <a-form-model-item label="统计时间" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="usageDate">
              <j-date placeholder="请选择统计时间" v-model="model.usageDate"  style="width: 100%" />
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="内存用量" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="ram">
              <a-input-number v-model="model.ram" placeholder="请输入内存用量" style="width: 100%" />
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="周期内CPU-小时数" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="totalVcpusUsage">
              <a-input-number v-model="model.totalVcpusUsage" placeholder="请输入周期内CPU-小时数" style="width: 100%" />
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="周期内磁盘GB-小时数" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="totalLocalGbUsage">
              <a-input-number v-model="model.totalLocalGbUsage" placeholder="请输入周期内磁盘GB-小时数" style="width: 100%" />
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="周期内的 RAM-小时数" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="totalMemoryMbUsage">
              <a-input-number v-model="model.totalMemoryMbUsage" placeholder="请输入周期内的 RAM-小时数" style="width: 100%" />
            </a-form-model-item>
          </a-col>
          <a-col :span="24">
            <a-form-model-item label="总运行时长" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="totalHours">
              <a-input v-model="model.totalHours" placeholder="请输入总运行时长"  ></a-input>
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
    name: 'OsResourceUsageForm',
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
           usageDate: [
              { required: true, message: '请输入统计时间!'},
           ],
           ram: [
              { required: true, message: '请输入内存用量!'},
           ],
           totalVcpusUsage: [
              { required: true, message: '请输入周期内CPU-小时数!'},
           ],
           totalLocalGbUsage: [
              { required: true, message: '请输入周期内磁盘GB-小时数!'},
           ],
           totalMemoryMbUsage: [
              { required: true, message: '请输入周期内的 RAM-小时数!'},
           ],
        },
        url: {
          add: "/openstack/osResourceUsage/add",
          edit: "/openstack/osResourceUsage/edit",
          queryById: "/openstack/osResourceUsage/queryById"
        }
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
    },
    methods: {
      add () {
        this.edit(this.modelDefault);
      },
      edit (record) {
        this.model = Object.assign({}, record);
        this.visible = true;
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
    }
  }
</script>